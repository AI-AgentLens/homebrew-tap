cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1846"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1846/agentshield_0.2.1846_darwin_amd64.tar.gz"
      sha256 "874110b1e359c3f1cccc24128f95ddb782d43ffbd5e7823b4f68614c2b8f4c00"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1846/agentshield_0.2.1846_darwin_arm64.tar.gz"
      sha256 "49976257f76a6719ae40a886955d3bb2c5b126716625f90e69b330d186aba2bd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1846/agentshield_0.2.1846_linux_amd64.tar.gz"
      sha256 "e7dd98fb5e719d179499d0e9951ec767f712838f16b30513023b0be7acf1d2cd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1846/agentshield_0.2.1846_linux_arm64.tar.gz"
      sha256 "977e437a0e0edd41e5ba0fee3d4ed70f517f19d0508ff4873d5203a7d2450f2b"
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
