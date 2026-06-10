cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1273"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1273/agentshield_0.2.1273_darwin_amd64.tar.gz"
      sha256 "e39ed1e1dcc908a36d7a37f1a7a2925569799e22fa74f999046e0f29e8abf8ff"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1273/agentshield_0.2.1273_darwin_arm64.tar.gz"
      sha256 "3d1d5b8aad53f9c7b9c4e28f6f22791d021f8359fc3712f719da783b5fa6be54"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1273/agentshield_0.2.1273_linux_amd64.tar.gz"
      sha256 "227f3db0c625d34ae902eb37bc3a93e39bc2c1b40380ca713d8f514089a6599a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1273/agentshield_0.2.1273_linux_arm64.tar.gz"
      sha256 "b69fbcfbe1b4d5eac37d4c56056f4ff56079be7266a58ad89307218b91cfa2fa"
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
