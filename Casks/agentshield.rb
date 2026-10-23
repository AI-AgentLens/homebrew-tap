cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2510"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2510/agentshield_0.2.2510_darwin_amd64.tar.gz"
      sha256 "b3787e6c6006bb9b1c77c81977c7280b1ce68edbd94dd812dc59d2e31911a8fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2510/agentshield_0.2.2510_darwin_arm64.tar.gz"
      sha256 "53d25e85a550976973f4b20c090104fb49b8aceb91b10ce2b7a8d83b35bfd582"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2510/agentshield_0.2.2510_linux_amd64.tar.gz"
      sha256 "fa04c8a966cb1e890a32eb600f90ccad2f08bc117bebb0247eeb768f8e5bb529"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2510/agentshield_0.2.2510_linux_arm64.tar.gz"
      sha256 "85612d0f1a1cb5574c545ce6136ecb65ed42b5eaf4f8838d89f980fbf35b7c00"
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
