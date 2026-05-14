cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.974"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.974/agentshield_0.2.974_darwin_amd64.tar.gz"
      sha256 "45f8559e479192425360c1c89473e750f10979a3c85083722143cd9a1451feec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.974/agentshield_0.2.974_darwin_arm64.tar.gz"
      sha256 "5647823d99f741a9e51bf01b0a2eb77716a5c787aef02c3856ada4267e93927f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.974/agentshield_0.2.974_linux_amd64.tar.gz"
      sha256 "9097e1739a8463aebef4c0bef9b3a0fd09da82b3c2646c53e42163f4ca8110d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.974/agentshield_0.2.974_linux_arm64.tar.gz"
      sha256 "52bc61cb5090ec655f95ac9e47d247a702a86d9783df986d1bf214ac4a8b72c3"
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
