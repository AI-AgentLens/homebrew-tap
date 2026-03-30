cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.248"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.248/agentshield_0.2.248_darwin_amd64.tar.gz"
      sha256 "4863b65fbc57dd894bd364d805ac8d88d7b8cd646d42f0b556be62f73cc141ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.248/agentshield_0.2.248_darwin_arm64.tar.gz"
      sha256 "eaea82165e7b6292c6ec91fcc29ab95eef90ee097000c4a0ce104498fe81a9c0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.248/agentshield_0.2.248_linux_amd64.tar.gz"
      sha256 "c349402a72b5395d653f77eee3f1aab8aa8baa8fdf6b59bb0396f71f60245aa6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.248/agentshield_0.2.248_linux_arm64.tar.gz"
      sha256 "710d123c6716bc5c49d8f45cc63e639795df4ef0497f1d2422694f7f8ddfc8bd"
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
