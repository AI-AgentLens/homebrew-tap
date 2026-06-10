cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1277"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1277/agentshield_0.2.1277_darwin_amd64.tar.gz"
      sha256 "706ca208547efb96640ac8a5d81dd5a63cabe79e5d2937cace2f025236e0acbf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1277/agentshield_0.2.1277_darwin_arm64.tar.gz"
      sha256 "067cca6528808a1c67383e326112390b43cfdb7e30c9562b6c6e0bd319f6761a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1277/agentshield_0.2.1277_linux_amd64.tar.gz"
      sha256 "42244a23faa81c05789095e5c01d0743f89ee8e0fb823abd3998f1f4f704d5ea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1277/agentshield_0.2.1277_linux_arm64.tar.gz"
      sha256 "ccccefb36b99dd98398640d25baad02629061500d0798f9ae44ed39b46ef6305"
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
