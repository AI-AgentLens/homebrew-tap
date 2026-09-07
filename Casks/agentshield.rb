cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2082"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2082/agentshield_0.2.2082_darwin_amd64.tar.gz"
      sha256 "e95a6ed67170ef99ec61d2e0b154881f9105a3825f941804468c560f6fe608ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2082/agentshield_0.2.2082_darwin_arm64.tar.gz"
      sha256 "e4c4fb35cd4092c079a224d978f522dea19761208fc19a601f2ebbda38479524"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2082/agentshield_0.2.2082_linux_amd64.tar.gz"
      sha256 "a7b09d35041c8105af30a68c0b76985b66ea3a6391619ea9b5206176000deea5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2082/agentshield_0.2.2082_linux_arm64.tar.gz"
      sha256 "ddf0c3701edd131e24de4fb4e19f28bba8c53072820e76e4deffdd4e10c0a3e0"
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
