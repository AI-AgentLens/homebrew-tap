cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1051"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1051/agentshield_0.2.1051_darwin_amd64.tar.gz"
      sha256 "937d7b3e46196f761facb2f287cac7541b5385b32894f0010c034c97c5f6805c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1051/agentshield_0.2.1051_darwin_arm64.tar.gz"
      sha256 "038854dcc309da868e13064039f9915d8813b7e54685fd8c37f0ead1f17071fa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1051/agentshield_0.2.1051_linux_amd64.tar.gz"
      sha256 "e0433126910ea1299c07b54f59863bb8d028e7c4660e3d39a3795c16b49630a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1051/agentshield_0.2.1051_linux_arm64.tar.gz"
      sha256 "cfa5cd2ff7c80df9bba127e82fc5fb3ae72c69308d483a6744560f7dd2e62dd0"
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
