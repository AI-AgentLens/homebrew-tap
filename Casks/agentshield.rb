cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1519"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1519/agentshield_0.2.1519_darwin_amd64.tar.gz"
      sha256 "624d90ce95e39ac08f5957c8a8d11f338b6cc66040d9623725a9a2eeede16ddf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1519/agentshield_0.2.1519_darwin_arm64.tar.gz"
      sha256 "5d93d4373699a40767097bc9fe1c91e42b8d5afd1b381ffc27cee30e83715441"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1519/agentshield_0.2.1519_linux_amd64.tar.gz"
      sha256 "4ffc1ca601136410e123bcfe814acdd90f5406d109cfc656ac2191e37878e08e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1519/agentshield_0.2.1519_linux_arm64.tar.gz"
      sha256 "41799aa37d902c7508d0edd90189b492df111b3671fa876aa53477f702ac02c9"
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
