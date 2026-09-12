cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2125"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2125/agentshield_0.2.2125_darwin_amd64.tar.gz"
      sha256 "4cc94e6e54fa8ceffc5aa1a211f9e09854f1de3d92f20e0d9414f7a8e2585b65"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2125/agentshield_0.2.2125_darwin_arm64.tar.gz"
      sha256 "e1a5d7b4fd11f4e882046af3516f8aa6c2c2ea5871722cb7d3fdf2075d69854b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2125/agentshield_0.2.2125_linux_amd64.tar.gz"
      sha256 "e4109caadc749fbc8701cc77e4b8f21c32c814e3aa88b4fae9726278d40cc097"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2125/agentshield_0.2.2125_linux_arm64.tar.gz"
      sha256 "732976e4221efbbcdf5eea6cb6b35867251005a2edd84ae834534bd0a0b71616"
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
