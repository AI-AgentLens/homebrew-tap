cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.281"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.281/agentshield_0.2.281_darwin_amd64.tar.gz"
      sha256 "54a6c2d6e20cccda89f08426c904668a8913dbad2a3261fb9c2842c6c804fef2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.281/agentshield_0.2.281_darwin_arm64.tar.gz"
      sha256 "b18267028987e9c4ef0ae4b7b46988a07fcff395aeb7ffb6fc8e6bde43b4cd0a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.281/agentshield_0.2.281_linux_amd64.tar.gz"
      sha256 "6f13858ee0f30e2fc67348d825cf83c2c7af913726e804733d5819391893f16b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.281/agentshield_0.2.281_linux_arm64.tar.gz"
      sha256 "05a049568a74be135620552ff0a56d108f78c0747616915b596cae3113b3a1bc"
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
