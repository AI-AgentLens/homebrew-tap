cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.692"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.692/agentshield_0.2.692_darwin_amd64.tar.gz"
      sha256 "49a9fdb2f138ca652c87d97092a32f64a8b741c51cdb42a50862eae39bd77202"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.692/agentshield_0.2.692_darwin_arm64.tar.gz"
      sha256 "b013f29c043b22e412126d6a0ee9fc2d5a5cb796c413dff556205d31a90b34a5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.692/agentshield_0.2.692_linux_amd64.tar.gz"
      sha256 "86563a6add6857a0adf6d65aff61ec13bfc5ff66a7b3b3ba192ee2876a4c18f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.692/agentshield_0.2.692_linux_arm64.tar.gz"
      sha256 "8b397aa9f8caa562b4b9950bfee9f4927a1bc80b530323ff77da5a6da7287136"
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
