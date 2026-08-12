cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1831"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1831/agentshield_0.2.1831_darwin_amd64.tar.gz"
      sha256 "64b06b17f0a6d80659aaa8eeb2916c4f7800a3bcabe312b4d461921b45dd894c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1831/agentshield_0.2.1831_darwin_arm64.tar.gz"
      sha256 "442b1dd09b69621a35cd5903e8eb94a0c58fe1f4226d34fabc0c38d862b7ea3f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1831/agentshield_0.2.1831_linux_amd64.tar.gz"
      sha256 "0efb7cbaa2f974792a4307e6a543e608902c78634fcbc04754a4654d2ccd5763"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1831/agentshield_0.2.1831_linux_arm64.tar.gz"
      sha256 "60a334f9987bd5c38bffb5f1fc4aeadf23f5b5baef9b614b9a8c733651f81bdb"
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
