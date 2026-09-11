cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2113"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2113/agentshield_0.2.2113_darwin_amd64.tar.gz"
      sha256 "3529900fbb14847f274ca500ad9c8b9481b4c1f18a1e77d2d576d39a49bae333"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2113/agentshield_0.2.2113_darwin_arm64.tar.gz"
      sha256 "31c8757260418fd86d604a1fbd30dc9534371182cb88e8fae80ecb828d2c9b36"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2113/agentshield_0.2.2113_linux_amd64.tar.gz"
      sha256 "f5d61658bd5dd8156ff0351d3b5d9ebbb8a02c7acf3aebb7552acbd05f042da6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2113/agentshield_0.2.2113_linux_arm64.tar.gz"
      sha256 "e06c011ee9b1a8f61a7e35153fa9afffbd9d8df90631ef137bdb9c5dba2f377f"
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
