cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1998"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1998/agentshield_0.2.1998_darwin_amd64.tar.gz"
      sha256 "28233e8ad451ee9b0445faace0da726ac8947e54983351693286a9c60623bd2a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1998/agentshield_0.2.1998_darwin_arm64.tar.gz"
      sha256 "88eae7f4b322004b07a4f19255803027e7caa32c1bd5a8ce3a13ce900895e16a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1998/agentshield_0.2.1998_linux_amd64.tar.gz"
      sha256 "a17c8e43589140edd368967421d34311b8fa321e8146a6f6c1de201b49ccc077"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1998/agentshield_0.2.1998_linux_arm64.tar.gz"
      sha256 "3afda1ee3a2565eff13237252904fddea35cc9192d9199559c1eeca5fe360fd3"
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
