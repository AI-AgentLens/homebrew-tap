cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.733"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.733/agentshield_0.2.733_darwin_amd64.tar.gz"
      sha256 "98ae6b78248875173dd838f6dba3139fccd8def37513755406834672c8bcfb78"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.733/agentshield_0.2.733_darwin_arm64.tar.gz"
      sha256 "3da50579245d60c4315766b80de7c68e57468e53b721bfb355b5962e3f647f09"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.733/agentshield_0.2.733_linux_amd64.tar.gz"
      sha256 "598b45880144618e285b8b5579c16d07f2397787fa1151e9e121cdddb7703274"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.733/agentshield_0.2.733_linux_arm64.tar.gz"
      sha256 "cec6dedb09dee15df907819052ad0975a247de330bf65bbd533b89cba52a2dc3"
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
