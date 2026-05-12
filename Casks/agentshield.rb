cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.963"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.963/agentshield_0.2.963_darwin_amd64.tar.gz"
      sha256 "8391e58e00bf2162cf65e33979877b54788c12ddef6ec4e8c9110b43cec24a81"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.963/agentshield_0.2.963_darwin_arm64.tar.gz"
      sha256 "0f4815aa36cc9f72cea1870fd5fb30220688cf859b970b98ca987674038502a6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.963/agentshield_0.2.963_linux_amd64.tar.gz"
      sha256 "c31c27e8ba84ffe099fb6fc8755311162c5951f0ac834199c4d54a46fac973f4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.963/agentshield_0.2.963_linux_arm64.tar.gz"
      sha256 "7140f1175c9eafcfd334aa746c1067f2b1ddd4aab6ebf5277731e8a48edda8ab"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
